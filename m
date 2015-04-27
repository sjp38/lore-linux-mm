Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 402336B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:46:35 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so143362024pdb.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:46:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n1si31776623pdf.241.2015.04.27.15.46.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:46:34 -0700 (PDT)
Date: Mon, 27 Apr 2015 15:46:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/13] mm: meminit: Move page initialization into a
 separate function.
Message-Id: <20150427154633.2134d804987dad88e008c2ff@linux-foundation.org>
In-Reply-To: <1429785196-7668-3-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-3-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:33:05 +0100 Mel Gorman <mgorman@suse.de> wrote:

> From: Robin Holt <holt@sgi.com>

: <holt@sgi.com>: host cuda-allmx.sgi.com[192.48.157.12] said: 550 cuda_nsu 5.1.1
:    <holt@sgi.com>: Recipient address rejected: User unknown in virtual alias
:    table (in reply to RCPT TO command)

Has Robin moved, or is SGI mail busted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
