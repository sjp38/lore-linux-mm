Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 483F06B025A
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:25:47 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so189448663pac.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:25:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sz8si531861pab.238.2015.11.09.15.25.46
        for <linux-mm@kvack.org>;
        Mon, 09 Nov 2015 15:25:46 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()
Date: Mon, 9 Nov 2015 23:25:44 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B83DE2@ORSMSX114.amr.corp.intel.com>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <5253459.IxnqkcU2vL@vostro.rjw.lan>
In-Reply-To: <5253459.IxnqkcU2vL@vostro.rjw.lan>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Russell King <linux@arm.linux.org.uk>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "drbd-user@lists.linbit.com" <drbd-user@lists.linbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, "codalist@coda.cs.cmu.edu" <codalist@coda.cs.cmu.edu>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Boris Petkov <bp@suse.de>

PiBBQ0sgZm9yIHRoZSBBQ1BJIGNoYW5nZXMgKGFuZCBDQ2luZyBUb255IGFuZCBCb3JpcyBmb3Ig
dGhlIGhlYWRzLXVwIGFzIHRoZXkNCj4gYXJlIHdheSBtb3JlIGZhbWFpbGlhciB3aXRoIHRoZSBB
UEVJIGNvZGUgdGhhbiBJIGFtKS4NCg0KU3VyZS4gSWYga3ZmcmVlKCkgcmVhbGx5IGlzIHNtYXJ0
IGVub3VnaCB0byBmaWd1cmUgaXQgb3V0IHRoZW4gdGhlcmUNCml0IG5vIHBvaW50IGluIHRoZSBp
ZiAoYmxhaCkga2ZyZWUoKSBlbHNlIHZmcmVlKCkuDQoNClRoZSBkcml2ZXJzL2FjcGkvYXBlaS9l
cnN0LmMgY29kZSBpc24ndCBkb2luZyBhbnl0aGluZyBzdWJ0bGUgb3IgbWFnaWMgaGVyZS4NCg0K
LVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
