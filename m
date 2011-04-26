Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 39BDC900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:49:28 -0400 (EDT)
Received: by wwi18 with SMTP id 18so1961732wwi.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:49:25 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 26 Apr 2011 13:49:25 +0800
Message-ID: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
Subject: readahead and oom
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

Hi,

When memory pressure is high, readahead could cause oom killing.
IMHO we should stop readaheading under such circumstances=E3=80=82If it's t=
rue
how to fix it?

--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
