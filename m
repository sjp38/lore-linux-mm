Message-ID: <46DFE46F.5020001@goop.org>
Date: Thu, 06 Sep 2007 12:28:47 +0100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <46DEFDF4.5000900@redhat.com> <46DF0013.4060804@qumranet.com> <46DF0234.7090504@redhat.com> <46DF045F.4020806@qumranet.com>
In-Reply-To: <46DF045F.4020806@qumranet.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, shaohua.li@intel.com, kvm-devel <kvm-devel@lists.sourceforge.net>, general@lists.openfabrics.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> It is, but the hooks are in much the same places.  It could be argued
> that you'd embed pte notifiers in paravirt_ops for a host kernel, but
> that's not doable because pte notifiers use higher-level data
> strutures (like vmas).

Also, I wouldn't like to preclude the possibility of having a kernel
that's both a guest and a host (ie, nested vmms).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
