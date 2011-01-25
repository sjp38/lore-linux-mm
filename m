Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 78AA36B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 07:41:39 -0500 (EST)
Received: from localhost.localdomain ([127.0.0.1]:47298 "EHLO
        duck.linux-mips.net" rhost-flags-OK-OK-OK-FAIL)
        by eddie.linux-mips.org with ESMTP id S1491188Ab1AYMlg (ORCPT
        <rfc822;linux-mm@kvack.org>); Tue, 25 Jan 2011 13:41:36 +0100
Date: Tue, 25 Jan 2011 13:41:04 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
Message-ID: <20110125124104.GA395@linux-mips.org>
References: <20110124210813.ba743fc5.yuasa@linux-mips.org>
 <4D3DD366.8000704@mvista.com>
 <20110124124412.69a7c814.akpm@linux-foundation.org>
 <20110124210752.GA10819@merkur.ravnborg.org>
 <AANLkTimdgYVpwbCAL96=1F+EtXyNxz5Swv32GN616mqP@mail.gmail.com>
 <20110124223347.ad6072f1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110124223347.ad6072f1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Sam Ravnborg <sam@ravnborg.org>, Sergei Shtylyov <sshtylyov@mvista.com>, Yoichi Yuasa <yuasa@linux-mips.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2011 at 10:33:47PM -0800, Andrew Morton wrote:

Works for me.

  Ralf

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
