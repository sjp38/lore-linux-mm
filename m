From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.68-mm3
Date: Wed, 30 Apr 2003 19:57:58 -0400
References: <20030429235959.3064d579.akpm@digeo.com>
In-Reply-To: <20030429235959.3064d579.akpm@digeo.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200304301957.58729.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On April 30, 2003 02:59 am, Andrew Morton wrote:
> Bits and pieces.  Nothing major, apart from the dynamic request allocation
> patch.  This arbitrarily increases the maximum requests/queue to 1024, and
> could well make large (and usually bad) changes to various benchmarks.
> However some will be helped.

Here is something a little broken.  Suspect it might be in 68-bk too:

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.68-mm3; fi
WARNING: /lib/modules/2.5.68-mm3/kernel/sound/oss/cs46xx.ko needs unknown symbol cs4x_ClearPageReserved

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
