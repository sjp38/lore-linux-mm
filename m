Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: page-flags.h
Date: Thu, 29 Aug 2002 21:04:59 +0200
References: <20020501192737.R29327@suse.de> <200205040646.g446kZrO008548@smtpzilla5.xs4all.nl> <3CE172C7.C250E7E8@zip.com.au>
In-Reply-To: <3CE172C7.C250E7E8@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17kUbE-00034u-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, ekonijn@xs4all.nl
Cc: Dave Jones <davej@suse.de>, Christoph Hellwig <hch@infradead.org>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 14 May 2002 22:25, Andrew Morton wrote:
> inlines in headers are just a pita.  I know it gets people
> all excited but I'd say: make 'em macros.

Responding to this old, old message - I strongly disagree.  Macros just suck 
too much, because of type safety and self-documentation issues.  Not only 
that, but using them extensively just lets the header inclusion order madness 
degenerate further.

Anyway, header inclusion order is a solved problem as far as I'm concerned, 
please see my patches/posts with 'early page' subject line, on lkml.  The 
winning strategy is to separate data declarations from function declarations, 
and automatically include the former in the latter.

It's true that I haven't brought these patches forward to 2.5, and for that I 
can be faulted.  There's still time though...

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
