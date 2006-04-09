From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
Date: Sun, 9 Apr 2006 09:01:13 +0200
References: <1144441108.5198.36.camel@localhost.localdomain>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604090901.13447.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 07 April 2006 22:18, Lee Schermerhorn wrote:
> This is a reposting of the migrate-on-fault series, against
> the 2.6.17-rc1-mm1 tree.  I would love to get some feedback on 
> these patches--especially regarding criteria for getting them
> into the mm tree for wider testing.

The biggest criteria would be some numbers that it actually
helps for something and doesn't break performance in other workloads.

For me it seems rather risky.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
