Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 535736B2B15
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:16:21 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id x3so7827809wru.22
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:16:21 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l4si22372513wri.77.2018.11.22.02.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 22 Nov 2018 02:16:20 -0800 (PST)
Date: Thu, 22 Nov 2018 11:16:12 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v2] kmemleak: Turn kmemleak_lock to raw spinlock on RT
Message-ID: <20181122101611.tmbmylbshd4mrnxi@linutronix.de>
References: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1542877459-144382-1-git-send-email-zhe.he@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhe.he@windriver.com
Cc: catalin.marinas@arm.com, tglx@linutronix.de, rostedt@goodmis.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org

On 2018-11-22 17:04:19 [+0800], zhe.he@windriver.com wrote:
> From: He Zhe <zhe.he@windriver.com>
>=20
> kmemleak_lock, as a rwlock on RT, can possibly be held in atomic context =
and
> causes the follow BUG.

please use
 [PATCH RT =E2=80=A6 ]

in future while posting for RT. And this was (and is) on my TODO list.

Sebastian
