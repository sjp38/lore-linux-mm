Message-ID: <461D0B80.2020005@redhat.com>
Date: Wed, 11 Apr 2007 12:23:28 -0400
From: Chuck Ebbert <cebbert@redhat.com>
MIME-Version: 1.0
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>	 <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>	 <ac8af0be0704110214qdca2ee9t3b44a17341e53730@mail.gmail.com>	 <20070411025305.b9131062.pj@sgi.com> <1176285976.6893.27.camel@twins> <ac8af0be0704110310n1f237e2el6f34365c4aaa5969@mail.gmail.com>
In-Reply-To: <ac8af0be0704110310n1f237e2el6f34365c4aaa5969@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Jackson <pj@sgi.com>, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Zhao Forrest wrote:
> On 4/11/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>> On Wed, 2007-04-11 at 02:53 -0700, Paul Jackson wrote:
>> > I'm confused - which end of ths stack is up?
>> >
>> > cpuset_exit doesn't call do_exit, rather it's the other
>> > way around.  But put_files_struct doesn't call do_exit,
>> > rather do_exit calls __exit_files calls put_files_struct.
>>
>> I'm guessing its x86_64 which generates crap traces.
>>
> Yes, it's x86_64. Is there a reliable way to generate stack traces under
> x86_64?
> Can enabling "[ ] Compile the kernel with frame pointers" help?

It will help a little, but not much because the stack backtrace
code ignores the frame pointers. But it will prevent tail calls,
making it somewhat easier to make sense of the data.

This should be a FAQ item somewhere...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
