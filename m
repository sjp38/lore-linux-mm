Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: MM patches against 2.5.31
Date: Mon, 26 Aug 2002 16:22:50 +0200
References: <3D644C70.6D100EA5@zip.com.au> <3D6989F7.9ED1948A@zip.com.au> <20020826091038.25100.qmail@thales.mathematik.uni-ulm.de>
In-Reply-To: <20020826091038.25100.qmail@thales.mathematik.uni-ulm.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17jKlX-0001i0-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>, Andrew Morton <akpm@zip.com.au>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 26 August 2002 11:10, Christian Ehrhardt wrote:
> + * A special Problem is the lru lists. Presence on one of these lists
> + * does not increase the page count.

Please remind me... why should it not?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
