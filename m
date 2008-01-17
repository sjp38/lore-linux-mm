Date: Thu, 17 Jan 2008 12:04:46 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <cfd9edbf0801160351i2b819f31j65cc16b1e694168f@mail.gmail.com>
References: <20080116114234.GA22460@elf.ucw.cz> <cfd9edbf0801160351i2b819f31j65cc16b1e694168f@mail.gmail.com>
Message-Id: <20080117120243.11D1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-2022-JP?B?IkRhbmllbCBTcBskQmlPGyhCZyI=?= <daniel.spang@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Pavel Machek <pavel@ucw.cz>, Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> > I'd read mem_notify as "tell me when new memory is unplugged" or
> > something. /dev/oom_notify? Plus, /dev/ names usually do not have "_"
> > in them.
> 
> I don't think we should use oom in the name, since the notification is
> sent long before oom.

OK, I don't change name.
Of cource, I will change soon if anyone propose more good name.

thanks

- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
