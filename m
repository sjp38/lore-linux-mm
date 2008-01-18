Message-ID: <47909FA4.1020205@sgi.com>
Date: Fri, 18 Jan 2008 04:46:28 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] percpu: Change Kconfig ARCH_SETS_UP_PER_CPU_AREA
 to HAVE_SETUP_PER_CPU_AREA
References: <20080117223505.203884000@sgi.com> <20080117223505.513183000@sgi.com> <20080118051118.GA14882@uranus.ravnborg.org>
In-Reply-To: <20080118051118.GA14882@uranus.ravnborg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Sam Ravnborg wrote:
> Hi Mike.
> 
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -20,6 +20,7 @@ config X86
>>  	def_bool y
>>  	select HAVE_OPROFILE
>>  	select HAVE_KPROBES
>> +	select HAVE_SETUP_PER_CPU_AREA if ARCH = "x86_64"
> 
> It is simpler to just say:
>> +	select HAVE_SETUP_PER_CPU_AREA if X86_64
> 
> And this is the way we do it in the rest of the
> x86 Kconfig files.
> 
> 	Sam


Thanks.  Done. :-)

And sorry about the premature mailing.  I have a set of scripts that
package everything up to send to test machines and it wasn't supposed
to trigger the "sendmail" phase to the distro list.  There are a few
build errors (as Ingo has noted) and I'm debugging an X86_64 !NUMA
problem that dies at network startup time.

But I'll add in all the suggestions from the "premature" reviews... :-)

Thanks again,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
