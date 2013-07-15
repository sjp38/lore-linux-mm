Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id EE4446B0080
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 21:05:23 -0400 (EDT)
Message-ID: <51E34A99.20503@asianux.com>
Date: Mon, 15 Jul 2013 09:04:25 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 0/2] mm/slub.c: beautify code of this file
References: <51DF5F43.3080408@asianux.com> <51DF778B.8090701@asianux.com> <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
In-Reply-To: <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

Beautify code for 80 column limitation and tab alignment (patch 1/2).

Also remove redundancy 'break' statement (patch 2/2).

---
 mm/slub.c |   93 ++++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 56 insertions(+), 37 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
