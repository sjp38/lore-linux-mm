From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: default base page size on ia64 processor
Date: Tue, 7 Nov 2006 00:23:10 -0800
Message-ID: <000001c70245$f6204f20$1b88030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'adheer chandravanshi' <adheerchandravanshi@gmail.com>, kernelnewbies <kernelnewbies@nl.linux.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

adheer chandravanshi wrote on Monday, November 06, 2006 11:45 PM
> Can anyone tell me what is the default base page size supported by
> ia64 processor on Linux?

16KB

> And can we change the base page size to some large page size like 16kb,64kb....?
> and how to do that?

Yes, via kernel config option.  Select "processor type and features",
then "page size".  You can select 4K, 8K, 16K, or 64K.

In the future, it's best to direct such question to ia64 mailing list:
linux-ia64@vger.kernel.org


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
