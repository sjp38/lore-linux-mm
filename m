Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE706B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 01:51:21 -0400 (EDT)
Received: from il06vts02.mot.com (il06vts02.mot.com [129.188.137.142])
	by mdgate1.mot.com (8.14.3/8.14.3) with SMTP id o3C5pYYi019558
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:51:34 -0600 (MDT)
Received: from mail-gw0-f54.google.com (mail-gw0-f54.google.com [74.125.83.54])
	by mdgate1.mot.com (8.14.3/8.14.3) with ESMTP id o3C5p3f7019473
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:51:34 -0600 (MDT)
Received: by mail-gw0-f54.google.com with SMTP id a12so2611204gwa.27
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 22:51:17 -0700 (PDT)
MIME-Version: 1.0
From: ShiYong LI <a22381@motorola.com>
Date: Mon, 12 Apr 2010 13:50:56 +0800
Message-ID: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com>
Subject: [PATCH - V2] Fix missing of last user while dumping slab corruption
	log
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, dwmw2@infradead.org, TAO HU <taohu@motorola.com>
List-ID: <linux-mm.kvack.org>

Hi,

Compared to previous version, add alignment checking to make sure
memory space storing redzone2 and last user tags is 8 byte alignment.
