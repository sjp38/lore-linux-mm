Date: Wed, 29 Nov 2006 20:04:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <20061129030655.941148000@menage.corp.google.com>
Message-ID: <Pine.LNX.4.64.0611292003480.19628@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Nov 2006, menage@google.com wrote:

> Comments? Also, can anyone clarify whether I need any locking when
> sacnning the pages in a pgdat? As far as I can see, even with memory
> hotplug this number can only increase, not decrease.

That depends on the way you scan...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
