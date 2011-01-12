Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F2476B00E7
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 13:05:32 -0500 (EST)
Date: Wed, 12 Jan 2011 12:05:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Rename struct task variables from p to tsk
In-Reply-To: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
Message-ID: <alpine.DEB.2.00.1101121205120.3053@router.home>
References: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Use t instead of p? Its a local variable after all.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
