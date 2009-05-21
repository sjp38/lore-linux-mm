Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 773336B005A
	for <linux-mm@kvack.org>; Thu, 21 May 2009 00:51:51 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id e12so269432fga.4
        for <linux-mm@kvack.org>; Wed, 20 May 2009 21:52:38 -0700 (PDT)
Subject: Re: [patch 2/5] Apply the PG_sensitive flag to mac80211 WEP key handling
References: <20090520184713.GB10756@oblivion.subreption.com>
From: Kalle Valo <kalle.valo@iki.fi>
Date: Thu, 21 May 2009 07:52:36 +0300
In-Reply-To: <20090520184713.GB10756@oblivion.subreption.com> (Larry H.'s message of "Wed\, 20 May 2009 11\:47\:13 -0700")
Message-ID: <87ljorm50r.fsf@litku.valot.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, linux-wireless@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Larry H." <research@subreption.com> writes:

> This patch deploys the use of the PG_sensitive page allocator flag
> within the mac80211 driver, more specifically the handling of WEP
> RC4 keys during encryption and decryption.

Why? Always explain the reason for the change in commit log. For
example, I have no idea why you want to change this.

> Signed-off-by: Larry H. <research@subreption.com>

Please add your last name.

-- 
Kalle Valo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
