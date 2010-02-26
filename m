Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E0EDB6B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 07:24:09 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Memory management woes - order 1 allocation failures
Date: Fri, 26 Feb 2010 13:24:07 +0100
References: <201002261232.28686.elendil@planet.nl>
In-Reply-To: <201002261232.28686.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002261324.08078.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 26 February 2010, Frans Pop wrote:
> As can be seen from the attached munin graph [1] the system has only 256
> MB memory, but that's quite normal for a simple NAS system.

Oops. Make that "only 128 MB".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
