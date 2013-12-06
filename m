Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id BFD946B006E
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 10:35:06 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id e16so578028qcx.31
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 07:35:06 -0800 (PST)
Received: from exchange10.columbia.tresys.com (exchange10.columbia.tresys.com. [216.30.191.171])
        by mx.google.com with ESMTPS id ko6si65158861qeb.9.2013.12.06.07.35.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Dec 2013 07:35:05 -0800 (PST)
From: William Roberts <WRoberts@tresys.com>
Subject: RE: [PATCH] - auditing cmdline
Date: Fri, 6 Dec 2013 15:34:32 +0000
Message-ID: <A8856C6323EFE0459533E910625AB930347FDF@Exchange10.columbia.tresys.com>
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
In-Reply-To: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>, "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rgb@redhat.com" <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Cc: "sds@tycho.nsa.gov" <sds@tycho.nsa.gov>

I sent out 3 patches on 12/2/2013. I didn't get any response. I thought I a=
dded the right people based on get_maintainers script.

Can anyone comment on these or point me in the right direction?

RGB, Can you at least ACK the audit subsystem patch " audit: Audit proc cmd=
line value"?

Thank you,
Bill

-----Original Message-----
From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf =
Of William Roberts
Sent: Monday, December 02, 2013 1:11 PM
To: linux-audit@redhat.com; linux-mm@kvack.org; linux-kernel@vger.kernel.or=
g; rgb@redhat.com; viro@zeniv.linux.org.uk
Cc: sds@tycho.nsa.gov
Subject: [PATCH] - auditing cmdline

This patch series relates to work started on the audit mailing list.
It eventually involved touching other modules, so I am trying to pull in th=
ose owners as well. In a nutshell I add new utility functions for accessing=
 a processes cmdline value as displayed in proc/<self>/cmdline, and then re=
factor procfs to use the utility functions, and then add the ability to the=
 audit subsystem to record this value.

Thanks for any feedback and help.

[PATCH 1/3] mm: Create utility functions for accessing a tasks
[PATCH 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
[PATCH 3/3] audit: Audit proc cmdline value

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to m=
ajordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
