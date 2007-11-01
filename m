Date: Thu, 1 Nov 2007 19:58:43 -0400
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071101235843.GA11213@dmt>
References: <20071030191827.GB31038@dmt> <20071030210743.GA304@dmt> <20071031172010.GA6005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071031172010.GA6005@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, drepper@redhat.com, riel@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 31, 2007 at 01:20:10PM -0400, Dave Jones wrote:
> On Tue, Oct 30, 2007 at 05:07:43PM -0400, Marcelo Tosatti wrote:
>  > +		case 13:
>  > +			filp->f_op = &oom_notify_fops;
>  > +			break;
> 
> Don't forget to add this to Documentation/devices.txt

Done.

>  > +	while (cpu < NR_CPUS) {
>  > +		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
>  > +
>  > +		cpu = next_cpu(cpu, *cpumask);
>  > +
>  > +		if (cpu < NR_CPUS)
>  > +			prefetch(&per_cpu(vm_event_states, cpu));
>  > +
>  > +		ret += this->event[vm_event];
>  > +	}
>  > +	return ret;
>  > +}
> 
> Is the prefetching worth it?

Taking into account that this is a generic function and as such any
member of this->event[] might be accessed, no... removed. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
