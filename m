Date: Wed, 9 May 2007 20:44:31 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
In-Reply-To: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
Message-ID: <Pine.LNX.4.61.0705092005060.29444@mtfhpc.demon.co.uk>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
 <20070430.150407.07642146.davem@davemloft.net>  <1177977619.24962.6.camel@localhost.localdomain>
  <20070430.173806.112621225.davem@davemloft.net>
 <Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
 <1177985136.24962.8.camel@localhost.localdomain>
 <Pine.LNX.4.61.0705011453380.4771@mtfhpc.demon.co.uk>
 <1178055110.13263.2.camel@localhost.localdomain>
 <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Ben,

Is it worth formally sending in either of my patches or does more work 
need to be done first?

If you would like me to test any changes, it takes me app. 2 hours to 
cross-compile a sparc kernel for my sun4c. I use my sparc system as a 
diskless client with a very minimal setup to alow me to test cross 
compiled GCC and any small platform independent code I may be working on.

I have not yet tried to get linux-2.6.21 or later working but for the test 
setup I have been using, it should not take too long if that is the kernel 
needed for testing.

I may also be able to do the same testing on an embedded PowerPC (32bit) 
(it will need some work to get my cross compilation system working again 
as some kernel changes in the ppc/powerpc architechture have proven to be 
incompatible with my build scripts) and on x86_64/ix86. Once I have fixed 
the build scripts, it will take app. 4 to 6 hours to get the initial NFS 
root minimal system built for these additional architectures and then app. 
2 hours for each test kernel build.

If a simple ADA build is not considered a suficiently harsh test, then I 
could cross compile a specialist test application, if one is available, or 
compile a more extensive application (maybe gcc) on the test system. The 
problem of compiling a more extensive application on the sparc system is 
that it is a slow system running as a diskless client with its NFS root on 
an aging i486 over a 10MBit Ethernet. The result is it will take days to 
compile somthing like gcc.

Regards
 	Mark Fortescue

On Wed, 2 May 2007, Mark Fortescue wrote:

>
>
> On Wed, 2 May 2007, Benjamin Herrenschmidt wrote:
>
>> 
>>> I have attached a patch (so pine does not mangle it) for linux-2.6.20.9.
>>> Is this what you had in mind?
>>> 
>>> For linux-2.6.21, more work will be needed as it has more code calling
>>> ptep_set_access_flags.
>> 
>> I'm not 100% sure we need the 'update' argument... we can remove the
>> whole old_entry, pte_same, etc... and just have pte_set_access_flags()
>> read the old PTE and decide wether something needs to be changed or not.
>> 
>> Ben.
>> 
>> 
>
> The attached patch works on sun4c (with my simple ADA compile test) but the 
> change in functionality may break things other platforms.
>
> The advantage of the previous patch is that the functionality is only changed 
> for sparc sun4c so less testing would be required.
>
> Regards
> 	Mark Fortescue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
