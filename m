Message-ID: <46F85431.1020306@tiscali.nl>
Date: Tue, 25 Sep 2007 02:20:01 +0200
From: roel <12o3l@tiscali.nl>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] x86: Convert cpuinfo_x86 array to a per_cpu array
 v3
References: <20070924210853.256462000@sgi.com> <20070924210853.516791000@sgi.com> <46F833D4.8050507@tiscali.nl> <20070924232423.GJ8127@redhat.com>
In-Reply-To: <20070924232423.GJ8127@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>, roel <12o3l@tiscali.nl>, travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Jones wrote:
> <excessive quoting trimmed, please don't quote 40K of text
>  to add a single line reply>

Ok, sorry, I don't know these rules

> On Tue, Sep 25, 2007 at 12:01:56AM +0200, roel wrote:
> 
>  > > --- a/arch/i386/kernel/cpu/cpufreq/powernow-k6.c
>  > > +++ b/arch/i386/kernel/cpu/cpufreq/powernow-k6.c
>  > > @@ -215,7 +215,7 @@ static struct cpufreq_driver powernow_k6
>  > >   */
>  > >  static int __init powernow_k6_init(void)
>  > >  {
>  > > -	struct cpuinfo_x86      *c = cpu_data;
>  > > +	struct cpuinfo_x86 *c = &cpu_data(0);
>  > >  
>  > >  	if ((c->x86_vendor != X86_VENDOR_AMD) || (c->x86 != 5) ||
>  > >  		((c->x86_model != 12) && (c->x86_model != 13)))
>  > 
>  > while we're at it, we could change this to
>  > 
>  >   	if (!(c->x86_vendor == X86_VENDOR_AMD && c->x86 == 5 &&
>  >   		(c->x86_model == 12 || c->x86_model == 13)))
> 
> For what purpose?  There's nothing wrong with the code as it stands,
> and inverting the tests means we'd have to move a bunch of
> code inside the if arm instead of just returning -ENODEV.

It's not inverting the test, so you don't need to move code. It evaluates 
the same, only the combined negation is moved to the front. I suggested it
to increase clarity, it results in the same assembly language.

Roel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
