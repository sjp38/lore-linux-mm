From: Con Kolivas <kernel@kolivas.org>
Subject: Re: -mm merge plans for 2.6.23
Date: Tue, 24 Jul 2007 10:08:19 +1000
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <200707102015.44004.kernel@kolivas.org>
In-Reply-To: <200707102015.44004.kernel@kolivas.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200707241008.20512.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 July 2007 20:15, Con Kolivas wrote:
> On Tuesday 10 July 2007 18:31, Andrew Morton wrote:
> > When replying, please rewrite the subject suitably and try to Cc: the
> > appropriate developer(s).
>
> ~swap prefetch
>
> Nick's only remaining issue which I could remotely identify was to make it
> cpuset aware:
> http://marc.info/?l=linux-mm&m=117875557014098&w=2
> as discussed with Paul Jackson it was cpuset aware:
> http://marc.info/?l=linux-mm&m=117895463120843&w=2
>
> I fixed all bugs I could find and improved it as much as I could last
> kernel cycle.
>
> Put me and the users out of our misery and merge it now or delete it
> forever please. And if the meaningless handwaving that I 100% expect as a
> response begins again, then that's fine. I'll take that as a no and you can
> dump it.

The window for 2.6.23 has now closed and your position on this is clear. I've 
been supporting this code in -mm for 21 months since 16-Oct-2005 without any 
obvious decision for this code forwards or backwards.

I am no longer part of your operating system's kernel's world; thus I cannot 
support this code any longer. Unless someone takes over the code base for 
swap prefetch you have to assume it is now unmaintained and should delete it.

Please respect my request to not be contacted further regarding this or any 
other kernel code.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
