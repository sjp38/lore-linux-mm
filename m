Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8D56B007B
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 04:52:22 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hn9so805707wib.1
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:52:21 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id w6si1255809eeg.153.2013.12.13.01.52.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Dec 2013 01:52:21 -0800 (PST)
Received: from [192.168.178.21] ([85.177.17.206]) by mail.gmx.com (mrgmx103)
 with ESMTPSA (Nemesis) id 0LbMb0-1V6YHu3XY2-00ktE1 for <linux-mm@kvack.org>;
 Fri, 13 Dec 2013 10:52:21 +0100
Message-ID: <52AAD8D4.2060807@gmx.de>
Date: Fri, 13 Dec 2013 10:52:20 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: why does index in truncate_inode_pages_range() grows so much
 ?
References: <529217CD.1000204@gmx.de> <20131203140214.GB31128@quack.suse.cz> <529E3450.9000700@gmx.de> <20131203230058.GA24037@quack.suse.cz> <20131204130639.GA31973@quack.suse.cz> <52A36389.7010103@gmx.de> <20131211202639.GE1163@quack.suse.cz>
In-Reply-To: <20131211202639.GE1163@quack.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: UML devel <user-mode-linux-devel@lists.sourceforge.net>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

On 12/11/2013 09:26 PM, Jan Kara wrote:
> Thanks! So this works more or less as expected - trinity issued a
> read at absurdly high offset so we created pagecache page a that
> offset and tried to read data into it. That failed. We left the
> page in the pagecache where it was for reclaim to reclaim it when
> free pages are needed. Everything works as designed except we could
> possibly argue that it's not the most efficient way to use
> pages...
> 
> Patch 'vfs: fix a bug when we do some dio reads with append dio
> writes' (http://www.spinics.net/lists/linux-fsdevel/msg70899.html)
> should actually change the situation and we won't unnecessarily
> cache these pages.
> 
confirmed - applied to latest git tree of Linus I helps.

- -- 
MfG/Sincerely
Toralf FA?rster
pgp finger print:1A37 6F99 4A9D 026F 13E2 4DCF C4EA CDDE 0076 E94E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iF4EAREIAAYFAlKq2NQACgkQxOrN3gB26U5LJgD/f0jU9NXrgVw7UthV613FrCMX
zUTRpvoNy8oKgpyiejwA/R2oVVwYXhKTcs0XHstQ9w3mjBcjp9t2ub2GAWa8hDnb
=KAh4
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
