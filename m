Received: by rv-out-0910.google.com with SMTP id l15so325678rvb
        for <linux-mm@kvack.org>; Thu, 25 Oct 2007 00:24:22 -0700 (PDT)
Message-ID: <84144f020710250024q683cfff2ubd1f8bda75415e2c@mail.gmail.com>
Date: Thu, 25 Oct 2007 10:24:22 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH+comment] fix tmpfs BUG and AOP_WRITEPAGE_ACTIVATE
In-Reply-To: <Pine.LNX.4.64.0710250705510.9811@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
	 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
	 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
	 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0710242152020.13001@blonde.wat.veritas.com>
	 <20071024140836.a0098180.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0710242233470.17796@blonde.wat.veritas.com>
	 <84144f020710242237q3aa8e96dtc8cf3f02f2af2cc9@mail.gmail.com>
	 <Pine.LNX.4.64.0710250705510.9811@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ezk@cs.sunysb.edu, ryan@finnie.org, mhalcrow@us.ibm.com, cjwatson@ubuntu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On 10/25/07, Hugh Dickins <hugh@veritas.com> wrote:
> With unionfs also fixed, we don't know of an absolute need for this
> patch (and so, on that basis, the !wbc->for_reclaim case could indeed
> be removed very soon); but as I see it, the unionfs case has shown
> that it's time to future-proof this code against whatever stacking
> filesystems come along.

Heh, what can I say, after several readings, I still find your above
explanation (which I totally agree with) more to the point than the
actual comment :-).

In any case, the patch looks good to me.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

                                  Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
