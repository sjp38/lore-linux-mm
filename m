Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.59-mm7
Date: Fri, 31 Jan 2003 20:18:01 -0500
References: <20030131001733.083f72c5.akpm@digeo.com>
In-Reply-To: <20030131001733.083f72c5.akpm@digeo.com>
MIME-Version: 1.0
Message-Id: <200301312018.02020.tomlins@cam.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Looks like something got missed...  I get this with mm7

if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.59-mm7; fi
WARNING: /lib/modules/2.5.59-mm7/kernel/arch/i386/kernel/apm.ko needs unknown symbol xtime_lock

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
