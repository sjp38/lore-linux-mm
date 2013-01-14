Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0FD6D6B0062
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 17:46:03 -0500 (EST)
Date: Mon, 14 Jan 2013 14:46:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/5] Add movablecore_map boot option
Message-Id: <20130114144601.1c40dc7e.akpm@linux-foundation.org>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
References: <1358154925-21537-1-git-send-email-tangchen@cn.fujitsu.com>
	<50F440F5.3030006@zytor.com>
	<20130114143456.3962f3bd.akpm@linux-foundation.org>
	<3908561D78D1C84285E8C5FCA982C28F1C97C2DA@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wujianguo@huawei.com" <wujianguo@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "linfeng@cn.fujitsu.com" <linfeng@cn.fujitsu.com>, "yinghai@kernel.org" <yinghai@kernel.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "rob@landley.net" <rob@landley.net>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "rientjes@google.com" <rientjes@google.com>, "guz.fnst@cn.fujitsu.com" <guz.fnst@cn.fujitsu.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "lliubbo@gmail.com" <lliubbo@gmail.com>, "jaegeuk.hanse@gmail.com" <jaegeuk.hanse@gmail.com>, "glommer@parallels.com" <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 14 Jan 2013 22:41:03 +0000
"Luck, Tony" <tony.luck@intel.com> wrote:

> > hm, why.  Obviously SRAT support will improve things, but is it
> > actually unusable/unuseful with the command line configuration?
> 
> Users will want to set these moveable zones along node boundaries
> (the whole purpose is to be able to remove a node by making sure
> the kernel won't allocate anything tricky in it, right?)  So raw addresses
> are usable ... but to get them right the user will have to go parse the
> SRAT table manually to come up with the addresses. Any time you
> make the user go off and do some tedious calculation that the computer
> should have done for them is user-abuse.
> 

Sure.  But SRAT configuration is in progress and the boot option is
better than nothing?

Things I'm wondering:

- is there *really* a case for retaining the boot option if/when
  SRAT support is available?

- will the boot option be needed for other archictectures, presumably
  because they don't provide sufficient layout information to the
  kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
