Date: Thu, 22 May 2003 14:05:02 +0200
From: Philippe =?ISO-8859-15?Q?Gramoull=E9?=
	<philippe.gramoulle@mmania.com>
Subject: Re: 2.5.69-mm8
Message-Id: <20030522140502.1ea09342.philippe.gramoulle@mmania.com>
In-Reply-To: <20030522021652.6601ed2b.akpm@digeo.com>
References: <20030522021652.6601ed2b.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Andrew,

It works fine here on a Dell Inspiron 8000 using elevator=as

I have a minor warning for the i8k module though:

WARNING: /lib/modules/2.5.69-mm8/kernel/drivers/char/i8k.ko needs unknown symbol SET_MODULE_OWNER

Thanks,

Philippe

--

Philippe Gramoulle
philippe.gramoulle@mmania.com
Lycos Europe - NOC France



On Thu, 22 May 2003 02:16:52 -0700
Andrew Morton <akpm@digeo.com> wrote:

  | 
  | ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm8/
  | 
  | . One anticipatory scheduler patch, but it's a big one.  I have not stress
  |   tested it a lot.  If it explodes please report it and then boot with
  |   elevator=deadline.
  | 
  | . The slab magazine layer code is in its hopefully-final state.
  | 
  | . Some VFS locking scalability work - stress testing of this would be
  |   useful.
  | 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
