From: Pasi Savolainen <psavo@iki.fi>
Subject: Re: 2.5.70-mm6
Date: Sun, 8 Jun 2003 22:52:37 +0000 (UTC)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <bc0enl$9cf$1@main.gmane.org>
References: <20030607151440.6982d8c6.akpm@digeo.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

* Andrew Morton <akpm@digeo.com>:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm6/

Xfree86 4.3.0 won't start on this one. -mm4 started fine.
X will stop (and seemingly hang) on PCI initialization and iteration stage.

> linus.patch

I'd say this is the source of this. Some cleanup along pci_for_each_dev
removal. All the 'fixes' (into while) don't even compile warningless.


-- 
   Psi -- <http://www.iki.fi/pasi.savolainen>
