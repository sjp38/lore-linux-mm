Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5E46B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 08:10:43 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cx13so29852132pac.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 05:10:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 1si3963286paj.218.2016.07.07.05.10.41
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 05:10:41 -0700 (PDT)
Date: Thu, 7 Jul 2016 20:09:10 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-stable-rc:linux-3.14.y 4656/4787]
 drivers/hid/hid-input.c:1087:2: note: in expansion of macro 'if'
Message-ID: <201607072053.iXKwk7Zu%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.14.y
head:   836a24d6291c76c802d0968be9efb050dbf955e6
commit: 3711edaf01a01818f2aed9f21efe29b9818134b9 [4656/4787] compiler-gcc: integrate the various compiler-gcc[345].h files
config: i386-randconfig-s1-201627 (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        git checkout 3711edaf01a01818f2aed9f21efe29b9818134b9
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/linux/list.h:4,
                    from include/linux/module.h:9,
                    from drivers/hid/hid-input.c:28:
   drivers/hid/hid-input.c: In function 'hidinput_hid_event':
   drivers/hid/hid-input.c:1087:67: warning: logical not is only applied to the left hand side of comparison [-Wlogical-not-parentheses]
     if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
                                                                      ^
   include/linux/compiler.h:134:30: note: in definition of macro '__trace_if'
     if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
                                 ^~~~
>> drivers/hid/hid-input.c:1087:2: note: in expansion of macro 'if'
     if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
     ^~
   drivers/hid/hid-input.c:1087:67: warning: logical not is only applied to the left hand side of comparison [-Wlogical-not-parentheses]
     if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
                                                                      ^
   include/linux/compiler.h:134:42: note: in definition of macro '__trace_if'
     if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
                                             ^~~~
>> drivers/hid/hid-input.c:1087:2: note: in expansion of macro 'if'
     if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
     ^~
   drivers/hid/hid-input.c:1087:67: warning: logical not is only applied to the left hand side of comparison [-Wlogical-not-parentheses]
     if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
                                                                      ^
   include/linux/compiler.h:145:16: note: in definition of macro '__trace_if'
      ______r = !!(cond);     \
                   ^~~~
>> drivers/hid/hid-input.c:1087:2: note: in expansion of macro 'if'
     if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
     ^~
--
   drivers/usb/gadget/f_fs.c: In function 'ffs_epfile_io':
>> drivers/usb/gadget/f_fs.c:670:17: warning: 'data_len' may be used uninitialized in this function [-Wmaybe-uninitialized]
      req->length   = data_len;
      ~~~~~~~~~~~~~~^~~~~~~~~~
--
   drivers/video/i740fb.c: In function 'i740fb_decode_var':
>> drivers/video/i740fb.c:661:26: warning: 'wm' may be used uninitialized in this function [-Wmaybe-uninitialized]
     par->lmi_fifo_watermark =
     ~~~~~~~~~~~~~~~~~~~~~~~~^
      i740_calc_fifo(par, 1000000 / var->pixclock, bpp);
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/uapi/linux/capability.h:16,
                    from include/linux/capability.h:15,
                    from include/linux/sched.h:13,
                    from include/linux/cgroup.h:11,
                    from kernel/cgroup.c:29:
   kernel/cgroup.c: In function 'parse_cgroupfs_options':
   include/linux/compiler.h:134:5: warning: suggest explicit braces to avoid ambiguous 'else' [-Wparentheses]
     if (__builtin_constant_p(!!(cond)) ? !!(cond) :   \
        ^
   include/linux/compiler.h:132:23: note: in expansion of macro '__trace_if'
    #define if(cond, ...) __trace_if( (cond , ## __VA_ARGS__) )
                          ^~~~~~~~~~
>> kernel/cgroup.c:1235:2: note: in expansion of macro 'if'
     if (all_ss || (!one_ss && !opts->none && !opts->name))
     ^~
   At top level:
   kernel/cgroup.c:3839:36: warning: 'cgroup_pidlist_seq_operations' defined but not used [-Wunused-const-variable=]
    static const struct seq_operations cgroup_pidlist_seq_operations = {
                                       ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
   net/bluetooth/hidp/core.c: In function 'hidp_connection_add':
>> net/bluetooth/hidp/core.c:1372:8: warning: 'session' may be used uninitialized in this function [-Wmaybe-uninitialized]
     ret = l2cap_register_user(conn, &session->user);
           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--
   In file included from sound/usb/usx2y/us122l.c:20:0:
   sound/usb/usx2y/us122l.c: In function 'snd_us122l_probe':
>> include/linux/usb.h:199:2: warning: 'card' may be used uninitialized in this function [-Wmaybe-uninitialized]
     dev_set_drvdata(&intf->dev, data);
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   sound/usb/usx2y/us122l.c:607:19: note: 'card' was declared here
     struct snd_card *card;
                      ^~~~
   In file included from sound/usb/usx2y/us122l.c:23:0:
>> include/sound/core.h:305:53: warning: 'card' may be used uninitialized in this function [-Wmaybe-uninitialized]
    #define snd_card_set_dev(card, devptr) ((card)->dev = (devptr))
                                                        ^
   sound/usb/usx2y/us122l.c:578:19: note: 'card' was declared here
     struct snd_card *card;
                      ^~~~
--
   In file included from sound/usb/usx2y/usbusx2y.c:139:0:
   sound/usb/usx2y/usbusx2y.c: In function 'snd_usX2Y_probe':
>> include/sound/core.h:305:53: warning: 'card' may be used uninitialized in this function [-Wmaybe-uninitialized]
    #define snd_card_set_dev(card, devptr) ((card)->dev = (devptr))
                                                        ^
   sound/usb/usx2y/usbusx2y.c:376:20: note: 'card' was declared here
     struct snd_card * card;
                       ^~~~

vim +/if +1087 drivers/hid/hid-input.c

20f6cd730 David Herrmann 2014-12-29  1071  	 * not only an optimization but also fixes 'dead' key reports. Some
20f6cd730 David Herrmann 2014-12-29  1072  	 * RollOver implementations for localized keys (like BACKSLASH/PIPE; HID
20f6cd730 David Herrmann 2014-12-29  1073  	 * 0x31 and 0x32) report multiple keys, even though a localized keyboard
20f6cd730 David Herrmann 2014-12-29  1074  	 * can only have one of them physically available. The 'dead' keys
20f6cd730 David Herrmann 2014-12-29  1075  	 * report constant 0. As all map to the same keycode, they'd confuse
20f6cd730 David Herrmann 2014-12-29  1076  	 * the input layer. If we filter the 'dead' keys on the HID level, we
20f6cd730 David Herrmann 2014-12-29  1077  	 * skip the keycode translation and only forward real events.
20f6cd730 David Herrmann 2014-12-29  1078  	 */
20f6cd730 David Herrmann 2014-12-29  1079  	if (!(field->flags & (HID_MAIN_ITEM_RELATIVE |
20f6cd730 David Herrmann 2014-12-29  1080  	                      HID_MAIN_ITEM_BUFFERED_BYTE)) &&
f3995eb51 Jiri Kosina    2015-01-06  1081  			      (field->flags & HID_MAIN_ITEM_VARIABLE) &&
20f6cd730 David Herrmann 2014-12-29  1082  	    usage->usage_index < field->maxusage &&
20f6cd730 David Herrmann 2014-12-29  1083  	    value == field->value[usage->usage_index])
20f6cd730 David Herrmann 2014-12-29  1084  		return;
20f6cd730 David Herrmann 2014-12-29  1085  
c01d50d18 Jiri Kosina    2007-08-20  1086  	/* report the usage code as scancode if the key status has changed */
c01d50d18 Jiri Kosina    2007-08-20 @1087  	if (usage->type == EV_KEY && !!test_bit(usage->code, input->key) != value)
c01d50d18 Jiri Kosina    2007-08-20  1088  		input_event(input, EV_MSC, MSC_SCAN, usage->hid);
1fe8736da Jiri Kosina    2007-08-09  1089  
dde5845a5 Jiri Kosina    2006-12-08  1090  	input_event(input, usage->type, usage->code, value);
dde5845a5 Jiri Kosina    2006-12-08  1091  
dde5845a5 Jiri Kosina    2006-12-08  1092  	if ((field->flags & HID_MAIN_ITEM_RELATIVE) && (usage->type == EV_KEY))
dde5845a5 Jiri Kosina    2006-12-08  1093  		input_event(input, usage->type, usage->code, 0);
dde5845a5 Jiri Kosina    2006-12-08  1094  }
dde5845a5 Jiri Kosina    2006-12-08  1095  

:::::: The code at line 1087 was first introduced by commit
:::::: c01d50d181f074a60bf3ed54eb055ce1679afb98 HID: Report usage codes of keys as EV_MSC scancode events

:::::: TO: Jiri Kosina <jkosina@suse.cz>
:::::: CC: Jiri Kosina <jkosina@suse.cz>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--lrZ03NoBR/3+SXJZ
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
tEsnzX3SX8D3sY3/A8At/lXtTQEA

--lrZ03NoBR/3+SXJZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
