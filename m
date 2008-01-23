Date: Wed, 23 Jan 2008 13:04:26 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [kvm-devel] [RFC][PATCH 2/5] add new exported function
 replace_page()
Message-ID: <20080123130426.45dad2db@bree.surriel.com>
In-Reply-To: <4794C40A.3020500@qumranet.com>
References: <4794C40A.3020500@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jan 2008 18:10:50 +0200
Izik Eidus <izike@qumranet.com> wrote:

> 

What prevents another CPU from freeing newpage while we run through
the start of replace_page() ?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
