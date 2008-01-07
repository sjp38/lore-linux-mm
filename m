Date: Mon, 7 Jan 2008 11:13:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02 of 11] avoid oom deadlock in nfs_create_request
In-Reply-To: <3ec0754b24738f5658ba.1199326148@v2.random>
Message-ID: <Pine.LNX.4.64.0801071113280.23617@schroedinger.engr.sgi.com>
References: <3ec0754b24738f5658ba.1199326148@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@cpushare.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
