Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE8E6B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:50:14 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id c84so41435611qkb.13
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:50:14 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h13si12283607qtb.233.2018.11.14.14.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 14:50:13 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <50baa4900e55b523f18eea2759f8efae@codeaurora.org>
Date: Wed, 14 Nov 2018 15:50:05 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <816A9750-D2A3-4BC8-88A6-41BFAA6A1540@oracle.com>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
 <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
 <5dcd06a0f84a4824bb9bab2b437e190d@AcuMS.aculab.com>
 <7C54170F-DE66-47E0-9C0D-7D1A97DCD339@oracle.com>
 <50baa4900e55b523f18eea2759f8efae@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Isaac J. Manjarres" <isaacm@codeaurora.org>
Cc: David Laight <David.Laight@aculab.com>, Kees Cook <keescook@chromium.org>, crecklin@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, psodagud@codeaurora.org, tsoni@codeaurora.org, stable@vger.kernel.org



> On Nov 14, 2018, at 10:32 AM, isaacm@codeaurora.org wrote:
>=20
> Thank you and David for your feedback. The check_bogus_address() =
routine is only invoked from one place in the kernel, which is =
__check_object_size(). Before invoking check_bogus_address, =
__check_object_size ensures that n is non-zero, so it is not possible to =
call this routine with n being 0. Therefore, we shouldn't run into the =
scenario you described. Also, in the case where we are copying a page's =
contents into a kernel space buffer and will not have that buffer =
interacting with userspace at all, this change to that check should =
still be valid, correct?

Having fixed more than one bug resulting from a "only called in one =
place" routine later being called elsewhere,
I am wary, but ultimately it's likely not worth the performance hit of a =
check or BUG_ON().

It's a generic math check for overflow, so it should work with any =
address.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>=
