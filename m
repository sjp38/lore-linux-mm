From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes
Date: Thu, 3 May 2007 10:59:18 +0200
References: <20070503022107.GA13592@kryten>
In-Reply-To: <20070503022107.GA13592@kryten>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705031059.18590.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org, clameter@sgi.com, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> Im guessing registering empty remote zones might make the SGI guys a bit
> unhappy, maybe we should just force the registration of empty local
> zones? Does anyone care?

I care. Don't do that please. Empty nodes cause all kinds of problems.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
