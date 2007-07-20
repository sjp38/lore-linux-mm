Message-ID: <46A097FE.3000701@redhat.com>
Date: Fri, 20 Jul 2007 07:09:50 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
References: <20070531002047.702473071@sgi.com>	 <20070531003012.302019683@sgi.com> <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>
In-Reply-To: <a781481a0707200341o21381742rdb15e6a9dc770d27@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satyam Sharma <satyam.sharma@gmail.com>
Cc: "clameter@sgi.com" <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Satyam Sharma wrote:
> [ Just cleaning up my inbox, and stumbled across this thread ... ]
> 
> 
> On 5/31/07, clameter@sgi.com <clameter@sgi.com> wrote:
>> Introduce CONFIG_STABLE to control checks only useful for development.
>>
>> Signed-off-by: Christoph Lameter <clameter@sgi.com>
>> [...]
>>  menu "General setup"
>>
>> +config STABLE
>> +       bool "Stable kernel"
>> +       help
>> +         If the kernel is configured to be a stable kernel then various
>> +         checks that are only of interest to kernel development will be
>> +         omitted.
>> +
> 
> 
> "A programmer who uses assertions during testing and turns them off
> during production is like a sailor who wears a life vest while drilling
> on shore and takes it off at sea."
>                                                - Tony Hoare
> 
> 
> Probably you meant to turn off debug _output_ (and not _checks_)
> with this config option? But we already have CONFIG_FOO_DEBUG_BAR
> for those situations ...

There are plenty of validation and debugging features in the kernel that go WAY 
beyond mere assertions, often imposing significant overhead (particularly when 
you scale up) or creating interfaces you'd never use unless you were doing 
kernel development work.  You really do want these features completely removed 
from production kernels.

The point of this is not to remove one-line WARN_ON and BUG_ON checks (though we 
might remove a few from fast paths), but rather to disable big chunks of 
debugging code that don't implement anything visible to a production workload.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
