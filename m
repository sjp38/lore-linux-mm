Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A8E596B01D3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 06:27:41 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2746892iwn.14
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 03:27:40 -0700 (PDT)
MIME-Version: 1.0
From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Date: Tue, 8 Jun 2010 11:27:10 +0100
Message-ID: <AANLkTikV3ZKYeZggPnuCgI7qBfN83d4d4q9JP3bsr43-@mail.gmail.com>
Subject: memory limit/quota per user
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello All,

Is it possible to limit memory quota per user (like disk quota) in linux ?

AFAIK, RLIMIT_* (i.e. RSS, DATA) are applicable per process not per user.

thankx a lot.
tharindu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
