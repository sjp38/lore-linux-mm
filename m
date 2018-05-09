Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5C26B02EE
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x205-v6so19044415pgx.19
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12-v6sor5202285pgr.217.2018.05.08.17.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:41 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [RFC][PATCH 00/13] Provide saturating helpers for allocation
Date: Tue,  8 May 2018 17:42:16 -0700
Message-Id: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This is a stab at providing three new helpers for allocation size
calculation:

struct_size(), array_size(), and array3_size().

These are implemented on top of Rasmus's overflow checking functions,
and the last 8 patches are all treewide conversions of open-coded
multiplications into the various combinations of the helper functions.

-Kees
