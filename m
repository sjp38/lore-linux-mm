Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AB4496B0114
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 22:24:31 -0400 (EDT)
Received: by iwn13 with SMTP id 13so1349852iwn.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 19:24:38 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 23 Aug 2009 01:54:02 +0900
Message-ID: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
Subject: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
From: Hiroaki Wakabayashi <primulaelatior@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

