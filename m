Received: by ug-out-1314.google.com with SMTP id m2so1537305uge
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 09:51:59 -0700 (PDT)
Message-ID: <29495f1d0706180951r2b7d0fe1gdcc0158011baf637@mail.gmail.com>
Date: Mon, 18 Jun 2007 09:51:59 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] madvise_need_mmap_write() usage
In-Reply-To: <Pine.LNX.4.64.0706181132020.23021@dhcp83-20.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0706151118150.11498@dhcp83-20.boston.redhat.com>
	 <20070616194130.GA6681@infradead.org>
	 <Pine.LNX.4.64.0706181132020.23021@dhcp83-20.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Baron <jbaron@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On 6/18/07, Jason Baron <jbaron@redhat.com> wrote:
>
> On Sat, 16 Jun 2007, Christoph Hellwig wrote:
>
> > On Fri, Jun 15, 2007 at 11:20:31AM -0400, Jason Baron wrote:
> > > hi,
> > >
> > > i was just looking at the new madvise_need_mmap_write() call...can we
> > > avoid an extra case statement and function call as follows?
> >
> > Sounds like a good idea, but please move the assignment out of the
> > conditional.
> >
>
> ok, here's an updated version:

You should always append the full patch, both the diff and the
rationale, I think. Even though it's quoted above, might make less
work for Andrew to pull in.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
