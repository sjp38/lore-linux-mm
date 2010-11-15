Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EA6388D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 01:07:58 -0500 (EST)
Received: by iwn9 with SMTP id 9so6780448iwn.14
        for <linux-mm@kvack.org>; Sun, 14 Nov 2010 22:07:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101114140920.E013.A69D9226@jp.fujitsu.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
	<877hgmr72o.fsf@gmail.com>
	<20101114140920.E013.A69D9226@jp.fujitsu.com>
Date: Mon, 15 Nov 2010 15:07:57 +0900
Message-ID: <AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 2:09 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Tue, =A09 Nov 2010 16:28:02 +0900 (JST), KOSAKI Motohiro <kosaki.moto=
hiro@jp.fujitsu.com> wrote:
>> > So, I don't think application developers will use fadvise() aggressive=
ly
>> > because we don't have a cross platform agreement of a fadvice behavior=
