Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A6D696B0055
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 04:46:56 -0400 (EDT)
Date: Tue, 14 Jul 2009 11:16:47 +0200
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: What to do with this message (2.6.30.1) ?
Message-Id: <20090714111647.5759d439.skraw@ithnet.com>
In-Reply-To: <4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
References: <20090713134621.124aa18e.skraw@ithnet.com>
	<4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 22:40:39 -0700
Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:

> [...]
> are you running jumbo frames perhaps?

there are no jumbo frames involved in this problem. All we do here is to rsync around a dozen hosts to the box in question.
Btw, there are _three_ e1000e inside this box:

01:00.0 Ethernet controller: Intel Corporation 82572EI Gigabit Ethernet Controller (Copper) (rev 06)
0d:00.0 Ethernet controller: Intel Corporation 82573V Gigabit Ethernet Controller (Copper) (rev 03)
0f:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller

-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
