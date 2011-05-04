Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 174796B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 09:01:49 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: mmc blkqueue is empty even if there are pending reads in do_generic_file_read()
Date: Wed, 4 May 2011 15:01:45 +0200
References: <BANLkTinhK_K1oSJDEoqD6EQK8Qy5Wy3v+g@mail.gmail.com> <201105032202.42662.arnd@arndb.de> <BANLkTinJxkauY+WUnJet+T5QM4_ROiKzGQ@mail.gmail.com>
In-Reply-To: <BANLkTinJxkauY+WUnJet+T5QM4_ROiKzGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201105041501.45796.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Per Forlin <per.forlin@linaro.org>
Cc: linux-mm@kvack.org, linux-mmc@vger.kernel.org, linaro-kernel@lists.linaro.org

On Tuesday 03 May 2011, Per Forlin wrote:
> > submitting small 512 byte read requests is a real problem when the
> > underlying page size is 16 KB. If your interpretation is right,
> > we should probably find a way to make it read larger chunks
> > on flash media.
> Sorry a typo. I missed out a "k" :)
> It reads 512k until 1M.

Ok, much better then.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
