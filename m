Date: Thu, 8 May 2003 13:23:39 +0200
From: Andi Kleen <ak@muc.de>
Subject: Redundant zonelist initialization
Message-ID: <20030508112339.GA7394@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@digeo.com
List-ID: <linux-mm.kvack.org>

When booting 2.5.69 on a 4 Node CONFIG_DISCONTIGMEM machine I get:

Building zonelist for node : 0
Building zonelist for node : 1
Building zonelist for node : 2
Building zonelist for node : 3
Building zonelist for node : 0
Building zonelist for node : 0
Building zonelist for node : 0
Building zonelist for node : 0

Why does it initialize the zonelist for node 0 five times?

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
