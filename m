Message-ID: <400D083F.6080907@aitel.hist.no>
Date: Tue, 20 Jan 2004 11:51:43 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm5 dies booting, possibly network related
References: <20040120000535.7fb8e683.akpm@osdl.org>
In-Reply-To: <20040120000535.7fb8e683.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.6.1-mm5 didn't get very far, only about a page of bootup messages.
The last two were:

NET registered protocol family 1
NET registered protocol family 10

And then nothing.  I tried twice - sysrq+B worked the first
time, not the second.  There were no oops or other messages.
I used the new mregparm=3 option - it works for 2.6.1-mm4

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
