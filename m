Received: (from jhall@localhost)
	by sith.maoz.com (8.12.9/8.12.9) id h3EIpZjV015008
	for linux-mm@kvack.org; Mon, 14 Apr 2003 11:51:35 -0700
From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304141851.h3EIpZjV015008@sith.maoz.com>
Subject: interrupt context
Date: Mon, 14 Apr 2003 14:51:35 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On a UP machine, is it possible for two interrupts to occur at once? as 
in, can card a create an interrupt while card b is in interrupt context?

what about an SMP machine operating in UP mode (nosmp)

_J
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
