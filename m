Date: Sun, 29 Jul 2007 23:01:33 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: Sparc32 not working:2.6.23-rc1 (git commit
 1e4dcd22efa7d24f637ab2ea3a77dd65774eb005)
In-Reply-To: <20070729205625.GK16817@stusta.de>
Message-ID: <Pine.LNX.4.61.0707292255540.31340@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0707281903350.27869@mtfhpc.demon.co.uk>
 <20070728234856.0fb78952.krzysztof.h1@wp.pl> <20070729003855.1c5422ed.krzysztof.h1@wp.pl>
 <Pine.LNX.4.61.0707290011300.28457@mtfhpc.demon.co.uk>
 <20070729174535.9eb6d0aa.krzysztof.h1@wp.pl> <Pine.LNX.4.61.0707291900010.31211@mtfhpc.demon.co.uk>
 <20070729205625.GK16817@stusta.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@stusta.de>
Cc: Krzysztof Helt <krzysztof.h1@wp.pl>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 29 Jul 2007, Adrian Bunk wrote:

> On Sun, Jul 29, 2007 at 07:26:29PM +0100, Mark Fortescue wrote:
>> ...
>> I am going to try to cherry pick a set of commits to see if I can't get a
>> better idear of where the memory corruption on sun4c is coming from. Build
>> problems sue to the DMA changes make git bisecting un-usable untill I have
>> found out which patches fix the DMA build issues.
>
> You have any known-good kernel?
>
> Boot back into this kernel for bisecting and compiling the kernels for
> bisecting there.
>

As I said, bisecting does not work if you can't build the kernel because 
of un-defined symbols spanning most of the revisions you are interested 
in.

I have isolated the revisions that do not build so I should be able to 
cerry pick a commit/commits that fixes the build issues. Once done, I will 
be able to investigate the original issue.

If it were practical to do a build test on all supported platforms before 
submitting patches then this would not be so much of an issue but ...

> cu
> Adrian
>
> -- 
>
>       "Is there not promise of rain?" Ling Tan asked suddenly out
>        of the darkness. There had been need of rain for many days.
>       "Only a promise," Lao Er said.
>                                       Pearl S. Buck - Dragon Seed
>
> -
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
