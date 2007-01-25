Received: by wx-out-0506.google.com with SMTP id s8so377254wxc
        for <linux-mm@kvack.org>; Wed, 24 Jan 2007 22:35:29 -0800 (PST)
Message-ID: <6d6a94c50701242235m48013856kb5a947c489d9da37@mail.gmail.com>
Date: Thu, 25 Jan 2007 14:35:29 +0800
From: "Aubrey Li" <aubreylee@gmail.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <45B82F41.9040705@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	 <45B75208.90208@linux.vnet.ibm.com>
	 <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com>
	 <45B82F41.9040705@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 1/25/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>
>
> Christoph Lameter wrote:
> > On Wed, 24 Jan 2007, Vaidyanathan Srinivasan wrote:
> >
> >> With your patch, MMAP of a file that will cross the pagecache limit hangs the
> >> system.  As I mentioned in my previous mail, without subtracting the
> >> NR_FILE_MAPPED, the reclaim will infinitely try and fail.
> >
> > Well mapped pages are still pagecache pages.
> >
>
> Yes, but they can be classified under a process RSS pages.  Whether it
> is an anon page or shared mem or mmap of pagecache, it would show up
> under RSS.  Those pages can be limited by RSS limiter similar to the
> one we are discussing in pagecache limiter.  In my opinion, once a
> file page is mapped by the process, then it should be treated at par
> with anon pages.  Application programs generally do not mmap a file
> page if the reuse for the content is very low.
>

I agree, we shouldn't take mmapped page into account.
But Vaidy - even with your patch, we are still using the existing
reclaimer, that means we dont ensure that only page cache is
reclaimed/limited. mapped pages will be hit also.
I think we still need to add a new scancontrol field to lock mmaped
pages and remove unmapped pagecache pages only.

-Aubrey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
