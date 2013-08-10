Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D87116B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 20:49:35 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5069404pbb.41
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 17:49:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1376080406-4r7r3uye-mutt-n-horiguchi@ah.jp.nec.com>
References: <CAMyfujfZayb8_673vkb2hdE9J_w+wPTD4aQ6TsY+aWxb9EzY8A@mail.gmail.com>
	<1376080406-4r7r3uye-mutt-n-horiguchi@ah.jp.nec.com>
Date: Sat, 10 Aug 2013 08:49:34 +0800
Message-ID: <CAMyfujeC_p-2cJteayPnA82wPRvoL2ekDNB6bd38d76v7Gb+6w@mail.gmail.com>
Subject: Re: [PATCH 1/1] pagemap: fix buffer overflow in add_page_map()
From: yonghua zheng <younghua.zheng@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Motohiro KOSAKI <kosaki.motohiro@gmail.com>

Update the patch according to Naoya's comment, I also run
./scripts/checkpatch.pl, and it passed ;D.
