Date: Thu, 18 Jul 2002 17:22:31 +0200 (MEST)
From: Szakacsits Szabolcs <szaka@sienet.hu>
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
In-Reply-To: <1026495039.1750.379.camel@sinai>
Message-ID: <Pine.LNX.4.30.0207181714420.30902-100000@divine.city.tvnet.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 12 Jul 2002, Robert Love wrote:

> I still encourage testing and comments.

Quickly looking through the patch I can't see what prevents total loss of
control at constant memory pressure. For more please see:
	http://www.uwsg.iu.edu/hypermail/linux/kernel/0108.2/0310.html

    Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
