From: Rudmer van Dijk <rudmer@legolas.dynup.net>
Subject: Re: 2.5.70-mm4
Date: Wed, 4 Jun 2003 23:33:26 +0200
References: <20030603231827.0e635332.akpm@digeo.com>
In-Reply-To: <20030603231827.0e635332.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200306042333.26850.rudmer@legolas.dynup.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 04 June 2003 08:18, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70
>-mm4/
>

I got the following errors with every file that includes 
include/linux/bitops.h

include/linux/bitops.h: In function `generic_hweight64':
include/linux/bitops.h:118: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:118: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:119: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:119: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:120: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:120: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:121: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:121: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:122: warning: integer constant is too large for "long" 
type
include/linux/bitops.h:122: warning: integer constant is too large for "long" 
type

This is on UP, athlon, gcc 3.3

	Rudmer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
