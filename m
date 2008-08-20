Date: Wed, 20 Aug 2008 16:20:19 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] Mlock:  revert mainline handling of mlock error return
In-Reply-To: <20080819210539.27199.97194.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook> <20080819210539.27199.97194.sendpatchset@lts-notebook>
Message-Id: <20080820161741.12CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> +	if (ret < 0)
>  		return ret;
> -	}
> -	return ret == len ? 0 : -ENOMEM;
> +	return ret == len ? 0 : -1;

Please don't use "-1".
user process interpret -1 as EPERM.

Yes, I know it isn't introduce by you.
it exist in original make_pages_present().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
