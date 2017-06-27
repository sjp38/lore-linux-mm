Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2306B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 23:18:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c12so16198707pfj.12
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 20:18:14 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g5si1220665plj.193.2017.06.26.20.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 20:18:13 -0700 (PDT)
Date: Tue, 27 Jun 2017 11:17:37 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 1/3] Protectable memory support
Message-ID: <201706271155.SBkfOuT6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Content-Disposition: inline
In-Reply-To: <20170626144116.27599-2-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: kbuild-all@01.org, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@gmail.com>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Igor,

[auto build test WARNING on mmotm/master]
[also build test WARNING on v4.12-rc7 next-20170626]
[cannot apply to linus/master linux/master]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Igor-Stoppa/ro-protection-for-dynamic-data/20170627-103230
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   mm/pmalloc.c: In function '__pmalloc_pool_show_avail':
>> mm/pmalloc.c:81:25: warning: format '%lu' expects argument of type 'long unsigned int', but argument 3 has type 'size_t {aka unsigned int}' [-Wformat=]
     return sprintf(buf, "%lu\n", gen_pool_avail(data->pool));
                            ^
   mm/pmalloc.c: In function '__pmalloc_pool_show_size':
   mm/pmalloc.c:91:25: warning: format '%lu' expects argument of type 'long unsigned int', but argument 3 has type 'size_t {aka unsigned int}' [-Wformat=]
     return sprintf(buf, "%lu\n", gen_pool_size(data->pool));
                            ^

vim +81 mm/pmalloc.c

    65		struct pmalloc_data *data;
    66	
    67		data = container_of(attr, struct pmalloc_data, attr_protected);
    68		if (atomic_read(&data->protected))
    69			return sprintf(buf, "protected\n");
    70		else
    71			return sprintf(buf, "unprotected\n");
    72	}
    73	
    74	static ssize_t __pmalloc_pool_show_avail(struct device *dev,
    75						 struct device_attribute *attr,
    76						 char *buf)
    77	{
    78		struct pmalloc_data *data;
    79	
    80		data = container_of(attr, struct pmalloc_data, attr_avail);
  > 81		return sprintf(buf, "%lu\n", gen_pool_avail(data->pool));
    82	}
    83	
    84	static ssize_t __pmalloc_pool_show_size(struct device *dev,
    85						struct device_attribute *attr,
    86						char *buf)
    87	{
    88		struct pmalloc_data *data;
    89	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--2oS5YaxWCcQjTEyO
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--2oS5YaxWCcQjTEyO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
