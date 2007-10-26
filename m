Received: by rv-out-0910.google.com with SMTP id l15so592796rvb
        for <linux-mm@kvack.org>; Fri, 26 Oct 2007 01:09:16 -0700 (PDT)
Message-ID: <84144f020710260109s56f9cdf2tcd7b7258fcb2bd8@mail.gmail.com>
Date: Fri, 26 Oct 2007 11:09:16 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <18209.19021.383347.160126@notabene.brown>
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
	 <18209.19021.383347.160126@notabene.brown>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 10/26/07, Neil Brown <neilb@suse.de> wrote:
> It seems that the new requirement is that if the address_space
> chooses not to write out the page, it should now call SetPageActive().
> If that is the case, I think it should be explicit in the
> documentation - please?

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
