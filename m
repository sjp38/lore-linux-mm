Received: from luxury.wat.veritas.com ([10.10.185.105]) (980 bytes) by megami
    via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m19RqIl-00001wC@megami> for
    <linux-mm@kvack.org>; Mon, 16 Jun 2003 02:29:23 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Mon, 16 Jun 2003 10:30:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: use_mm/unuse_mm correctness
In-Reply-To: <20030616121322.A10735@in.ibm.com>
Message-ID: <Pine.LNX.4.44.0306161029030.1469-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Suparna Bhattacharya <suparna@in.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Jun 2003, Suparna Bhattacharya wrote:
> 
> However, in the aio case, use_mm and unuse_mm are called 
> only by workqueue threads, so there shouldn't be any 
> migration even if a pre-empt occurs (cpus_allowed is fixed 
> to a particular cpu), should it ?

Ah, yes, I certainly hope the cpu can't change in such a case!
Sorry for the noise, I hope someone else can help,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
