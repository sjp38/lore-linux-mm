Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D84076B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 16:33:47 -0500 (EST)
Received: by mail-ia0-f172.google.com with SMTP id l29so1527968iag.3
        for <linux-mm@kvack.org>; Sat, 23 Feb 2013 13:33:47 -0800 (PST)
Date: Sat, 23 Feb 2013 13:40:35 -0600
From: Rob Landley <rob@landley.net>
Subject: Re: [Bug fix PATCH 0/2] Make whatever node kernel resides in
 un-hotpluggable.
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com>
	<20130220133650.4e0913f3.akpm@linux-foundation.org>
In-Reply-To: <20130220133650.4e0913f3.akpm@linux-foundation.org> (from
	akpm@linux-foundation.org on Wed Feb 20 15:36:50 2013)
Message-Id: <1361648435.11282.10@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/20/2013 03:36:50 PM, Andrew Morton wrote:
> and while we're there, let's pause to admire how prescient I was in
> refusing to merge all this into 3.8-rc1 :)

I'm on a plane, which is why I am not digging out the Dr. Who episode =20
"planet of the spiders", digitizing the "All praise to the great one" =20
chant, and attaching it to this email. (So, consider yourself lucky, I =20
guess.)

Rob
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
