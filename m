Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 347DE6B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:08:08 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] cris: add pgprot_noncached
Date: Tue, 23 Jun 2009 22:07:42 +0200
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <200906231455.31499.arnd@arndb.de> <20090623192041.GH12383@axis.com>
In-Reply-To: <20090623192041.GH12383@axis.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200906232207.46136.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Jesper Nilsson <Jesper.Nilsson@axis.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, "magnus.damm@gmail.com" <magnus.damm@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jayakumar.lkml@gmail.com" <jayakumar.lkml@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 23 June 2009, Jesper Nilsson wrote:
> No, this looks good to me.
> Do you want me to grab it for the CRIS tree or do you want
> to keep it as a series?

I'd prefer you to take it. The order of the four patches is
entirely arbitrary anyway and there are no other dependencies
on it once the asm-generic version is merged.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
