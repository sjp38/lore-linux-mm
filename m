Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.44-mm5
Date: Fri, 25 Oct 2002 20:34:21 +0200
References: <3DB8D94B.20D3D5BD@digeo.com>
In-Reply-To: <3DB8D94B.20D3D5BD@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E1859Hr-0008PO-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 25 October 2002 07:40, Andrew Morton wrote:
> url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.44/2.5.44-mm5/
> 
> We seem to have found the dud patch.  Things should be a little
> more stable...
> 
> The CONFIG_PREEMPT+SMP problem I was having went away when gcc-2.95.3
> was used in place of 2.91.66.  Which is a bit of a problem because
> _someone_ has to keep an eye on 2.91.66 compatibility as long as it
> continues to be required for sparc builds.

Didn't davem say something about being ready to move to a more recent
compiler, or does my memory not serve correctly?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
