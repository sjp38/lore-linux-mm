Received: by rv-out-0910.google.com with SMTP id l15so592110rvb
        for <linux-mm@kvack.org>; Fri, 26 Oct 2007 01:05:14 -0700 (PDT)
Message-ID: <84144f020710260105w358bf6f0m6c373108b9aab9a8@mail.gmail.com>
Date: Fri, 26 Oct 2007 11:05:14 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <Pine.LNX.4.64.0710251556300.1521@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
	 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
	 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
	 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
	 <84144f020710221348x297795c0qda61046ec69a7178@mail.gmail.com>
	 <Pine.LNX.4.64.0710251556300.1521@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org, neilb@suse.de
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On 10/25/07, Hugh Dickins <hugh@veritas.com> wrote:
> @@ -349,10 +349,6 @@ static pageout_t pageout(struct page *pa
>                 res = mapping->a_ops->writepage(page, &wbc);
>                 if (res < 0)
>                         handle_write_error(mapping, page, res);
> -               if (res == AOP_WRITEPAGE_ACTIVATE) {
> -                       ClearPageReclaim(page);
> -                       return PAGE_ACTIVATE;
> -               }

I don't see ClearPageReclaim added anywhere. Is that done on purpose?
Other than that, the patch looks good to me and I think we should
stick it into -mm to punish Andrew for his secret hack ;-).

                                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
